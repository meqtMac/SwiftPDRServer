# install swift Dependency
sudo apt update
sudo apt-get install \
          binutils \
          git \
          gnupg2 \
          libc6-dev \
          libcurl4 \
          libedit2 \
          libgcc-9-dev \
          libpython2.7 \
          libsqlite3-0 \
          libstdc++-9-dev \
          libxml2 \
          libz3-dev \
          pkg-config \
          tzdata \
          uuid-dev \
          zlib1g-dev

# download swift package
wget https://download.swift.org/swift-5.8-release/ubuntu2004/swift-5.8-RELEASE/swift-5.8-RELEASE-ubuntu20.04.tar.gz
tar xzf swift-5.8-RELEASE-ubuntu20.04.tar.gz
sudo mv swift-5.8-RELEASE-ubuntu20.04/ /usr/share/swift

# add swift to path
if [ -n "$BASH_VERSION" ]; then
  echo 'export PATH="/usr/share/swift/usr/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc
elif [ -n "$ZSH_VERSION" ]; then
  echo 'export PATH="/usr/share/swift/usr/bin:$PATH"' >> ~/.zshrc
  source ~/.zshrc
else
  echo "Warning: shell not supported. Please add /usr/share/swift/usr/bin to your PATH manually."
fi
