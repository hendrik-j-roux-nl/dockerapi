# DockerFile
# Empty Linux container, as per the Docker Desktop installation
# Get base SDK Image from Microsoft to build the project
FROM mcr.Microsoft.com/dotnet/core/sdk:2.2 AS build-env

# Working directory within the Docker container
WORKDIR /app

# Copy the XSPROJ file and restore any dependencies (via NUGET) into the container
# dotnet store resolves any dependencies
COPY *.csproj ./
RUN dotnet restore 

# Copy the project files and build the release into container working directory
COPY . ./
# Compiled "Release" version of project into the folder out
RUN dotnet publish -c Release -o out

# Generate runtime image and use the .Net code runtime only inside container
FROM mcr.Microsoft.com/dotnet/core/aspnet:2.2
WORKDIR /app
# Expose port 80 on the container
EXPOSE 80
# Multi-part build, combining parts from the previous steps and putting that into working directory
COPY --from=build-env /app/out .

# Container start
ENTRYPOINT ["dotnet", "DockerAPI.dll"]