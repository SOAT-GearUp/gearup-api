using GearUp.Api.Controllers;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Hosting;

namespace GearUp.Api.UnitTests.Controllers;

public sealed class DiagnosticoControllerTests
{
    [Fact]
    public void GerarErro_EmDesenvolvimento_DeveLancarExcecaoIntencional()
    {
        var controller = new DiagnosticoController(CriarAmbiente(Environments.Development));

        var exception = Assert.Throws<InvalidOperationException>(() => controller.GerarErro());

        Assert.Equal("Erro intencional para validacao da observabilidade.", exception.Message);
    }

    [Fact]
    public void GerarErro_ForaDeDesenvolvimento_DeveRetornarNotFound()
    {
        var controller = new DiagnosticoController(CriarAmbiente(Environments.Production));

        var result = controller.GerarErro();

        Assert.IsType<NotFoundResult>(result);
    }

    private static AmbienteTeste CriarAmbiente(string nome) =>
        new AmbienteTeste
        {
            EnvironmentName = nome
        };

    private sealed class AmbienteTeste : IWebHostEnvironment
    {
        public string ApplicationName { get; set; } = "GearUp.Api.UnitTests";
        public IFileProvider WebRootFileProvider { get; set; } = new NullFileProvider();
        public string WebRootPath { get; set; } = string.Empty;
        public string EnvironmentName { get; set; } = Environments.Production;
        public string ContentRootPath { get; set; } = string.Empty;
        public IFileProvider ContentRootFileProvider { get; set; } = new NullFileProvider();
    }
}
