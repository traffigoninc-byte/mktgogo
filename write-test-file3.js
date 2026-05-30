const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, 'src', 'services', 'payment.service.e2e.test.ts');

const part3 = `
  // Req 3.2, 3.3 - Commission split with vendor-specific rate
  describe('Req 3.2, 3.3 - Commission split with vendor-specific rate', () => {
    it('uses vendor-specific commission rate when set', async () => {
      const vendorRate = 0.10;
      await pool.query('INSERT INTO vendor_commission_rates (vendor_id, commission_rate) VALUES ($1, $2) ON CONFLICT (vendor_id) DO UPDATE SET commission_rate = EXCLUDED.commission_rate', [VENDOR_ID, vendorRate]);

      const amount = 300.00;
      const expectedCommission = parseFloat((amount * vendorRate).toFixed(2));
      const expectedVendorAmount = amount - expectedCommission;

      const orderId = makeOrderId();
      const { payment } = await paymentService.initiatePayment({
        orderId, vendorId: VENDOR_ID, amount, currency: CURRENCY,
        gateway: 'stripe', customerEmail: CUSTOMER_EMAIL, idempotencyKey: makeIdempotencyKey(),
      });

      const completed = await paymentService.completePayment(payment.id, payment.gatewayPaymentId);

      expect(completed.commissionAmount).toBeCloseTo(expectedCommission, 2);
      expect(completed.vendorAmount).toBeCloseTo(expectedVendorAmount, 2);
      expect(completed.commissionRate).toBeCloseTo(vendorRate, 4);

      const commissionRecord = await commissionRepository.findByPaymentId(completed.id);
      expect(commissionRecord.commissionRate).toBeCloseTo(vendorRate, 4);
      expect(commissionRecord.commissionAmount).toBeCloseTo(expectedCommission, 2);

      await pool.query('DELETE FROM vendor_commission_rates WHERE vendor_id = $1', [VENDOR_ID]);
    });

    it('commission plus vendor amount always equals total payment amount', async () => {
      const testCases = [{ amount: 100.00 }, { amount: 33.33 }, { amount: 1.00 }, { amount: 999.99 }];

      for (const tc of testCases) {
        const orderId = makeOrderId();
        const { payment } = await paymentService.initiatePayment({
          orderId, vendorId: VENDOR_ID, amount: tc.amount, currency: CURRENCY,
          gateway: 'stripe', customerEmail: CUSTOMER_EMAIL, idempotencyKey: makeIdempotencyKey(),
        });

        const completed = await paymentService.completePayment(payment.id, payment.gatewayPaymentId);
        expect(completed.commissionAmount + completed.vendorAmount).toBeCloseTo(tc.amount, 2);
      }
    });
  });

  // Req 3.4 - Payment failure rollback
  describe('Req 3.4 - Payment failure rollback', () => {
    it('marks payment as failed when gateway throws during initiation', async () => {
      gatewayAdapter.createPayment.mockRejectedValueOnce(new Error('Card declined'));

      const orderId = makeOrderId();

      await expect(
        paymentService.initiatePayment({
          orderId, vendorId: VENDOR_ID, amount: 100.00, currency: CURRENCY,
          gateway: 'stripe', customerEmail: CUSTOMER_EMAIL, idempotencyKey: makeIdempotencyKey(),
        })
      ).rejects.toThrow('Card declined');

      const payments = await paymentRepository.findByOrderId(orderId);
      expect(payments.length).toBe(1);
      expect(payments[0].status).toBe('failed');
    });

    it('does not credit wallet when payment initiation fails', async () => {
      gatewayAdapter.createPayment.mockRejectedValueOnce(new Error('Gateway unavailable'));

      const walletBefore = await walletRepository.findByVendorAndCurrency(VENDOR_ID, CURRENCY);
      const balanceBefore = walletBefore ? walletBefore.balance : 0;

      const orderId = makeOrderId();
      await expect(
        paymentService.initiatePayment({
          orderId, vendorId: VENDOR_ID, amount: 500.00, currency: CURRENCY,
          gateway: 'stripe', customerEmail: CUSTOMER_EMAIL, idempotencyKey: makeIdempotencyKey(),
        })
      ).rejects.toThrow();

      const walletAfter = await walletRepository.findByVendorAndCurrency(VENDOR_ID, CURRENCY);
      const balanceAfter = walletAfter ? walletAfter.balance : 0;
      expect(balanceAfter).toBeCloseTo(balanceBefore, 2);
    });

    it('completePayment is idempotent for already-completed payments', async () => {
      const orderId = makeOrderId();
      const amount = 80.00;

      const { payment } = await paymentService.initiatePayment({
        orderId, vendorId: VENDOR_ID, amount, currency: CURRENCY,
        gateway: 'stripe', customerEmail: CUSTOMER_EMAIL, idempotencyKey: makeIdempotencyKey(),
      });

      const first = await paymentService.completePayment(payment.id, payment.gatewayPaymentId);
      expect(first.status).toBe('completed');

      const walletAfterFirst = await walletRepository.findByVendorAndCurrency(VENDOR_ID, CURRENCY);
      const balanceAfterFirst = walletAfterFirst.balance;

      const second = await paymentService.completePayment(payment.id, payment.gatewayPaymentId);
      expect(second.status).toBe('completed');

      const walletAfterSecond = await walletRepository.findByVendorAndCurrency(VENDOR_ID, CURRENCY);
      expect(walletAfterSecond.balance).toBeCloseTo(balanceAfterFirst, 2);
    });
  });
`;

fs.appendFileSync(filePath, part3, 'utf8');
console.log('Part 3 appended, size:', fs.statSync(filePath).size);
