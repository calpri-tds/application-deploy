# Use the official ASP.NET Core SDK image as the build environment
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-env

# Set the working directory inside the container
WORKDIR /app

# Copy the necessary files
COPY aspnetapp/*.csproj ./
COPY aspnetapp/*.config ./

# Restore dependencies with optimized layer caching
RUN dotnet restore

# Copy the entire project directory into the container
COPY aspnetapp/ ./

# Build the application with release configuration
RUN dotnet publish -c Release -o out

# Use a smaller runtime image for the final image
FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS runtime

# Set the working directory inside the container
WORKDIR /app

# Copy the published application from the build environment
COPY --from=build-env /app/out ./

# Expose port 80 for the application
EXPOSE 80

# Set the entrypoint to start the application
ENTRYPOINT ["dotnet", "aspnetapp.dll"]
