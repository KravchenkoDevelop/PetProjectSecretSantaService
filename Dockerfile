FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 4443

FROM base as debug
RUN tdnf install procps-ng -y
ENV DOTNET_USE_LOGGING_CONFIGURATION=true
ENV DOTNET_ENVIRONMENT=Development

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Http.API/SecretSanta.Http.API.csproj", "Http.API/"]
COPY ["SecretSanta.Common/SecretSanta.Services.Common.csproj", "SecretSanta.Common/"]
COPY ["SecretSanta.Services.ConpanionSearch/SecretSanta.Services.ConpanionSearch.csproj", "SecretSanta.Services.ConpanionSearch/"]
COPY ["SecretSanta.Services.Event/SecretSanta.Services.Event.csproj", "SecretSanta.Services.Event/"]
COPY ["SecretSanta.Services.Tennant/SecretSanta.Services.Tennant.csproj", "SecretSanta.Services.Tennant/"]
COPY ["SecretSanta.Services.User/SecretSanta.Services.User.csproj", "SecretSanta.Services.User/"]
RUN dotnet restore "Http.API/SecretSanta.Http.API.csproj"
COPY . .
WORKDIR "/src/Http.API"
RUN  dotnet build "SecretSanta.Http.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build as publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "SecretSanta.Http.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish


FROM base as final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT [ "dotnet",  "SecretSanta.Http.API.dll"]