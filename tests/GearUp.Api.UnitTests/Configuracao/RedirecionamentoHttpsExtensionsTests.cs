using GearUp.Api.Configuracao;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Hosting;

namespace GearUp.Api.UnitTests.Configuracao;

public sealed class RedirecionamentoHttpsExtensionsTests
{
    [Fact]
    public async Task EmDesenvolvimento_DeveManterRequisicaoHttp()
    {
        var pipeline = CriarPipeline(Environments.Development);
        var contexto = CriarContextoHttp();

        await pipeline(contexto);

        Assert.Equal(StatusCodes.Status204NoContent, contexto.Response.StatusCode);
        Assert.Null(contexto.Response.Headers.Location.FirstOrDefault());
    }

    [Fact]
    public async Task ForaDeDesenvolvimento_DeveRedirecionarParaHttps()
    {
        var pipeline = CriarPipeline(Environments.Production);
        var contexto = CriarContextoHttp();

        await pipeline(contexto);

        Assert.Equal(StatusCodes.Status307TemporaryRedirect, contexto.Response.StatusCode);
        Assert.Equal("https://localhost/health/live", contexto.Response.Headers.Location);
    }

    private static RequestDelegate CriarPipeline(string nomeAmbiente)
    {
        var builder = WebApplication.CreateBuilder(new WebApplicationOptions
        {
            EnvironmentName = nomeAmbiente
        });
        builder.Services.AddHttpsRedirection(options => options.HttpsPort = 443);

        var app = builder.Build();
        app.UseHttpsRedirectionForaDeDesenvolvimento(new AmbienteTeste(nomeAmbiente));
        app.Run(context =>
        {
            context.Response.StatusCode = StatusCodes.Status204NoContent;
            return Task.CompletedTask;
        });

        return ((IApplicationBuilder)app).Build();
    }

    private static DefaultHttpContext CriarContextoHttp() =>
        new()
        {
            Request =
            {
                Scheme = "http",
                Host = new HostString("localhost"),
                Path = "/health/live"
            }
        };

    private sealed class AmbienteTeste(string nome) : IHostEnvironment
    {
        public string EnvironmentName { get; set; } = nome;
        public string ApplicationName { get; set; } = "GearUp.Api.UnitTests";
        public string ContentRootPath { get; set; } = string.Empty;
        public IFileProvider ContentRootFileProvider { get; set; } = new NullFileProvider();
    }
}
