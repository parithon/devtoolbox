FROM mcr.microsoft.com/windows:1909

WORKDIR /bootstrap

COPY _build .

RUN powershell -command "& {Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force;Install-PackageProvider -Name NuGet -Force}" && powershell -File bootstrap.ps1

WORKDIR /devtoolbox

COPY src .

CMD [ "powershell", "Invoke-Pester" ]
