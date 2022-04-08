[Main](README.md)

# Introduction
If you are interested to run this Solution locally as a Developer, you will need to make sure you have the Azurite emulator, and a local instance of SQL Server running. I recommand installing Docker Desktop so you can install these dependencies which is the easist way to get started. Once you have configured Docker Desktop, you can run the following which uses Docker to install Storage and SQL dependencies.

```
.\LocalEnv\Install.ps1 -Password <Password>
```