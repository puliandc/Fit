# iOS Build Environment Dockerfile
# Created by Jason Lu on 20:56:00 10/11/2025
# For cross-platform iOS development

FROM macos-base:latest

# Environment variables
ENV DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
ENV FASTLANE_USER=your-email@example.com
ENV FASTLANE_TEAM=6P6P5HUVGU

# Install development tools
RUN brew update && \
    brew install fastlane cocoapods swiftlint swiftformat && \
    brew cleanup

# Set working directory
WORKDIR /app

# Copy project files
COPY Fit/ ./Fit/
COPY Fit.xcodeproj/ ./Fit.xcodeproj/
COPY scripts/ ./scripts/
COPY Package.swift* ./
COPY Podfile* ./

# Install dependencies
RUN if [ -f Podfile ]; then pod install; fi
RUN if [ -f Package.swift ]; then swift package resolve; fi

# Expose ports for development server
EXPOSE 8080

# Default command
CMD ["./scripts/build-devops.sh", "full", "Release"]