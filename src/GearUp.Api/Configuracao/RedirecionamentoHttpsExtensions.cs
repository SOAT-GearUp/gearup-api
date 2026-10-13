namespace GearUp.Api.Configuracao;

internal static class RedirecionamentoHttpsExtensions
{
    public static IApplicationBuilder UseHttpsRedirectionForaDeDesenvolvimento(
        this IApplicationBuilder app,
        IHostEnvironment ambiente)
    {
        if (!ambiente.IsDevelopment())
            app.UseHttpsRedirection();

        return app;
    }
}
