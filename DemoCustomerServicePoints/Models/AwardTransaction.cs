using System.ComponentModel.DataAnnotations;

namespace DemoCustomerServicePoints.Models
{
    public class AwardTransaction
    {
        [Key]
        public string TransactionId { get; set; }

        public DateTime Awarded { get; set; }
    }
}
