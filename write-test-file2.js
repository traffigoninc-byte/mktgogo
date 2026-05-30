const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'src', 'services', 'payment.service.e2e.test.ts');

const part2 = `
  // Req 3.1 - Payment initiation creates pending record
  describe('Req 3.1 - Payment initiation creates pending record', () => {
    it('creates a payment record with status pending when customer initiates payment', async () => {
      const orderId = makeOrderId();
      const amount = 100.00;

      const { payment } = await paymentService.initiatePayment({
        orderId, vendorId: VENDOR_ID, amount, currency: CURRENCY,
        gateway: 'stripe', customerEmail: CUSTOMER_EMAIL, idempotencyKey: makeIdempotencyKey(),
      });

      expect(payment).toBeDefined();
      expect(payment.id).toBeTruthy();
      expect(payment.orderId).toBe(orderId);
      expect(payment.vendorId).toBe(VENDOR_ID);
      expect(payment.amount).toBe(amount);
      expect(payment.currency).toBe(CURRENCY);
      expect(payment.gateway).toBe('stripe');
      expect(payment.status).toBe('pending');
      expect(gatewayAdapter.createPayment).toHaveBeenCalledTimes(1);
      expect(payment.gatewayPaymentId).toBeTruthy();

      const stored = await paymentRepository.findById(payment.id);
      expect(stored).not.toBeNull();
      expect(stored.status).toBe('pending');
    });

    it('returns existing payment on duplicate idempotency key', async () => {
      const idempotencyKey = makeIdempotencyKey();
      const orderId = makeOrderId();

      const { payment: first } = await paymentService.initiatePayment({
        orderId, vendorId: VENDOR_ID, amount: 50.00, currency: CURRENCY,
        gateway: 'stripe', customerEmail: CUSTOMER_EMAIL, idempotencyKey,
      });

      const { payment: second } = await paymentService.initiatePayment({
        orderId, vendorId: VENDOR_ID, amount: 50.00, currency: CURRENCY,
        gateway: 'stripe', customerEmail: CUSTOMER_EMAIL, idempotencyKey,
      });

      expect(second.id).toBe(first.id);
      expect(gatewayAdapter.createPayment).toHaveBeenCalledTimes(1);
    });
  });

  // Req 3.1, 3.2, 3.3, 4.2 - Complete payment flow end-to-end
  describe('Req 3.1, 3.2, 3.3, 4.2 - Complete payment flow end-to-end', () => {
    it('full flow: initiate then complete then commission split then wallet credited', async () => {
      const orderId = makeOrderId();
      const amount = 200.00;
      const commissionRate = 0.15;
      const expectedCommission = parseFloat((amount * commissionRate).toFixed(2));
      const expectedVendorAmount = amount - expectedCommission;

      const { payment: pendingPayment } = await paymentService.initiatePayment({
        orderId, vendorId: VENDOR_ID, amount, currency: CURRENCY,
        gateway: 'stripe', customerEmail: CUSTOMER_EMAIL, idempotencyKey: makeIdempotencyKey(),
      });

      expect(pendingPayment.status).toBe('pending');
      const gatewayPaymentId = pendingPayment.gatewayPaymentId;
      expect(gatewayPaymentId).toBeTruthy();

      const walletBefore = await walletRepository.findByVendorAndCurrency(VENDOR_ID, CURRENCY);
      const balanceBefore = walletBefore ? walletBefore.balance : 0;

      const completedPayment = await paymentService.completePayment(pendingPayment.id, gatewayPaymentId);

      expect(completedPayment.status).toBe('completed');
      expect(completedPayment.id).toBe(pendingPayment.id);
      expect(completedPayment.commissionAmount).toBeCloseTo(expectedCommission, 2);
      expect(completedPayment.vendorAmount).toBeCloseTo(expectedVendorAmount, 2);

      const walletAfter = await walletRepository.findByVendorAndCurrency(VENDOR_ID, CURRENCY);
      expect(walletAfter).not.toBeNull();
      expect(walletAfter.balance).toBeCloseTo(balanceBefore + expectedVendorAmount, 2);
    });

    it('verifies all database records created correctly after payment completion', async () => {
      const orderId = makeOrderId();
      const amount = 150.00;
      const commissionRate = 0.15;
      const expectedCommission = parseFloat((amount * commissionRate).toFixed(2));
      const expectedVendorAmount = amount - expectedCommission;

      const { payment: pendingPayment } = await paymentService.initiatePayment({
        orderId, vendorId: VENDOR_ID, amount, currency: CURRENCY,
        gateway: 'stripe', customerEmail: CUSTOMER_EMAIL, idempotencyKey: makeIdempotencyKey(),
      });

      const completedPayment = await paymentService.completePayment(pendingPayment.id, pendingPayment.gatewayPaymentId);

      // payments table
      const storedPayment = await paymentRepository.findById(completedPayment.id);
      expect(storedPayment).not.toBeNull();
      expect(storedPayment.status).toBe('completed');
      expect(storedPayment.amount).toBe(amount);
      expect(storedPayment.commissionAmount).toBeCloseTo(expectedCommission, 2);
      expect(storedPayment.vendorAmount).toBeCloseTo(expectedVendorAmount, 2);
      expect(storedPayment.commissionRate).toBeCloseTo(commissionRate, 4);
      expect(storedPayment.gatewayPaymentId).toBeTruthy();

      // commission_records table
      const commissionRecord = await commissionRepository.findByPaymentId(completedPayment.id);
      expect(commissionRecord).not.toBeNull();
      expect(commissionRecord.paymentId).toBe(completedPayment.id);
      expect(commissionRecord.orderId).toBe(orderId);
      expect(commissionRecord.vendorId).toBe(VENDOR_ID);
      expect(commissionRecord.amount).toBe(amount);
      expect(commissionRecord.commissionRate).toBeCloseTo(commissionRate, 4);
      expect(commissionRecord.commissionAmount).toBeCloseTo(expectedCommission, 2);
      expect(commissionRecord.currency).toBe(CURRENCY);
      expect(commissionRecord.createdAt).toBeInstanceOf(Date);

      // wallet_transactions table
      const transactions = await walletService.getTransactions({
        vendorId: VENDOR_ID, currency: CURRENCY, type: 'credit', category: 'payment', limit: 50,
      });

      const paymentTx = transactions.find(tx => tx.reference === completedPayment.id);
      expect(paymentTx).toBeDefined();
      expect(paymentTx.type).toBe('credit');
      expect(paymentTx.category).toBe('payment');
      expect(paymentTx.amount).toBeCloseTo(expectedVendorAmount, 2);
      expect(paymentTx.createdAt).toBeInstanceOf(Date);
    });

    it('wallet balance accumulates correctly across multiple payments', async () => {
      await pool.query('DELETE FROM wallet_transactions WHERE wallet_id IN (SELECT id FROM wallets WHERE vendor_id = $1)', [VENDOR_ID]);
      await pool.query('DELETE FROM wallets WHERE vendor_id = $1', [VENDOR_ID]);

      const payments = [
        { amount: 100.00, expectedVendorAmount: 85.00 },
        { amount: 200.00, expectedVendorAmount: 170.00 },
        { amount: 50.00,  expectedVendorAmount: 42.50 },
      ];

      let expectedBalance = 0;

      for (const p of payments) {
        const orderId = makeOrderId();
        const { payment } = await paymentService.initiatePayment({
          orderId, vendorId: VENDOR_ID, amount: p.amount, currency: CURRENCY,
          gateway: 'stripe', customerEmail: CUSTOMER_EMAIL, idempotencyKey: makeIdempotencyKey(),
        });
        await paymentService.completePayment(payment.id, payment.gatewayPaymentId);
        expectedBalance += p.expectedVendorAmount;
      }

      const wallet = await walletRepository.findByVendorAndCurrency(VENDOR_ID, CURRENCY);
      expect(wallet).not.toBeNull();
      expect(wallet.balance).toBeCloseTo(expectedBalance, 2);
    });
  });
`;

fs.appendFileSync(filePath, part2, 'utf8');
console.log('Part 2 appended, size:', fs.statSync(filePath).size);
