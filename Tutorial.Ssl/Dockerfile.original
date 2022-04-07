FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["nuget.config", "."]
COPY ["Tutorial.Ssl/Tutorial.Ssl.csproj", "Tutorial.Ssl/"]
RUN dotnet restore "Tutorial.Ssl/Tutorial.Ssl.csproj"
COPY . .
WORKDIR "/src/Tutorial.Ssl"
RUN dotnet build "Tutorial.Ssl.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Tutorial.Ssl.csproj" -c Release -o /app/publish

#--- Generate ROOT Cert---
FROM base AS ssl
WORKDIR /https-root
COPY ["tutorial-root-cert.cer","."]
RUN openssl x509 -inform DER -in /https-root/tutorial-root-cert.cer -out /https-root/tutorial-root-cert.crt
#-------------------------

FROM base AS final

#--- Copy API Cert and register Root Cert ---
WORKDIR /https
COPY ["tutorial-ssl-cert.pfx","."]
COPY --from=ssl /https-root/tutorial-root-cert.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates
#--------------------------------------------

WORKDIR /app
COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "Tutorial.Ssl.dll"]