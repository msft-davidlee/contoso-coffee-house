namespace DemoCustomerServicePoints.Core
{
    public class LineItem
    {
        /// <summary>
        /// Product SKU
        /// </summary>
        public string SKU { get; set; }

        /// <summary>
        /// Dollar amount spent rounded for the purpose of calculating points.
        /// </summary>
        public int RoundedAmountSpent { get; set; }
    }

    public class AwardPointsTransaction
    {
        /// <summary>
        /// Member Id.
        /// </summary>
        public string MemberId { get; set; }

        /// <summary>
        /// List of items purchased in the transaction.
        /// </summary>
        public LineItem[] LineItems { get; set; }

        /// <summary>
        /// Relates to the transaction that qualifies for this add.
        /// </summary>
        public string TransactionId { get; set; }

        /// <summary>
        /// Date of the transaction.
        /// </summary>
        public DateTime TransactionDate { get; set; }
    }
}
