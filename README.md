```
 ██████╗███████╗██████╗ ██████╗  ██████╗ ██████╗ 
██╔════╝██╔════╝██╔══██╗██╔══██╗██╔═══██╗██╔══██╗
██║     ███████╗██║  ██║██████╔╝██║   ██║██████╔╝
██║     ╚════██║██║  ██║██╔══██╗██║   ██║██╔═══╝ 
╚██████╗███████║██████╔╝██║  ██║╚██████╔╝██║     
 ╚═════╝╚══════╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝     
```
> **Drag. Drop. Done.**  
> A zero-config C# compiler for Windows. No IDE. No project files. No nonsense.

---

## `> WHAT IS IT`

**CSDROP** is a single `.bat` file that compiles C# source files the moment you drag them onto it. It auto-detects whatever compiler is available on your machine and outputs a ready-to-run `.exe` next to your source files.

No setup. No config. No Visual Studio required.

---

## `> USAGE`

```
1. Drop one or more .cs files onto compile_cs.bat
2. Watch it compile
3. Run your .exe
```

That's it.

---

## `> COMPILER AUTO-DETECTION`

CSDROP checks for a compiler in this order:

```
[1] csc.exe on PATH         ← Roslyn (Visual Studio / .NET SDK)
[2] .NET Framework csc.exe  ← Checks Framework64 + Framework (v4, v3.5, v2.0)
[3] dotnet CLI              ← Spins up a temp project, builds, cleans up
```

If none are found, CSDROP tells you exactly what to install and where.

---

## `> OUTPUT`

```
Input:   MyProgram.cs  (or multiple .cs files)
Output:  MyProgram.exe (same directory as your source)
```

When compiling multiple files, the output is named after the **first** file dropped.

---

## `> REQUIREMENTS`

| Requirement | Details |
|---|---|
| OS | Windows 7 / 10 / 11 |
| Compiler | Any one of: .NET SDK, Visual Studio, or .NET Framework |
| No .NET at all? | Install from [dotnet.microsoft.com](https://dotnet.microsoft.com/download) |

---

## `> YOUR CODE`

CSDROP compiles standard C# console applications. Your entry point should look like one of these:

```csharp
// Classic (all versions)
class Program {
    static void Main() {
        // your code
    }
}

// Top-level statements (C# 9+, .NET 5+)
Console.WriteLine("Hello!");
```

---

## `> FILES`

```
📂 CSDROP
 ├── compile_cs.bat   ← the compiler script
 ├── Hello.cs         ← test file
 └── README.md        ← you are here
```

---

## `> QUICK TEST`

Drop `Hello.cs` onto `compile_cs.bat`.  
You should see `Hello.exe` appear and be prompted to run it.  
If it works — you're good to go.

---

```
[ CSDROP ] — built for people who just want to run their code
```
