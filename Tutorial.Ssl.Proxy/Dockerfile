FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["nuget.config", "."]
COPY ["Tutorial.Ssl.Proxy/Tutorial.Ssl.Proxy.csproj", "Tutorial.Ssl.Proxy/"]
RUN dotnet restore "Tutorial.Ssl.Proxy/Tutorial.Ssl.Proxy.csproj"
COPY . .
WORKDIR "/src/Tutorial.Ssl.Proxy"
RUN dotnet build "Tutorial.Ssl.Proxy.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Tutorial.Ssl.Proxy.csproj" -c Release -o /app/publish

#--- Generate ROOT Cert---
FROM base AS ssl
WORKDIR /https-root
COPY ["tutorial-root-cert.cer","."]
RUN openssl x509 -inform DER -in /https-root/tutorial-root-cert.cer -out /https-root/tutorial-root-cert.crt
#-------------------------

FROM base AS final

#--- Copy API Cert and register Root Cert ---
COPY --from=ssl /https-root/tutorial-root-cert.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates
#--------------------------------------------

WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Tutorial.Ssl.Proxy.dll"]