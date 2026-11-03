using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GearUp.Api.Controllers;

[ApiController]
[Route("api/diagnostico")]
[Authorize(Roles = "Admin")]
[ApiExplorerSettings(IgnoreApi = true)]
public sealed class DiagnosticoController(IWebHostEnvironment environment) : ControllerBase
{
    [HttpPost("erro")]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public IActionResult GerarErro()
    {
        if (!environment.IsDevelopment())
            return NotFound();

        throw new InvalidOperationException(
            "Erro intencional para validacao da observabilidade.");
    }
}
