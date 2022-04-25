using DemoCustomerServicePoints.Core;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Identity.Web.Resource;

namespace DemoCustomerServicePoints.ApiControllers
{
    [Authorize]
    [RequiredScope(RequiredScopesConfigurationKey = "AzureAd:Scopes")]
    [Route("api/[controller]")]
    [ApiController]
    public class PointsController : ControllerBase
    {
        private readonly IPointsService _pointsService;

        public PointsController(IPointsService pointsService)
        {
            _pointsService = pointsService;
        }

        [HttpPost]
        public async Task<AwardPointsResult> Add(AwardPointsTransaction awardPoints)
        {
            var points = await _pointsService.AddPoints(awardPoints);
            return new AwardPointsResult { TotalPoints = points };
        }

        [Route("member/{memberId}")]
        [HttpGet]
        public async Task<AwardPointsResult> Get(string memberId)
        {
            var points = await _pointsService.GetPoints(memberId);
            return new AwardPointsResult { TotalPoints = points };
        }
    }
}
