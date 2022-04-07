#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

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

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Tutorial.Ssl.dll"]
