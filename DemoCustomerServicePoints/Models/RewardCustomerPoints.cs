using System.ComponentModel.DataAnnotations;

namespace DemoCustomerServicePoints.Models
{
    public class RewardCustomerPoints
    {
        [Key]
        public string MemberId { get; set; }

        public int Points { get; set; }
    }
}
