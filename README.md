
# Windows Maintenance Script

## Overview

This repository contains a robust Batch script for automating routine Windows maintenance tasks. It offers an efficient and systematic approach to ensuring the health and performance of Windows systems, ideal for IT administrators and advanced users. The script covers critical maintenance areas such as service monitoring, disk cleanup, DISM operations, network resets, event log management, and more.

---

## Key Features

### **Logging and Setup**
- Automatically creates a log directory and a `maintenance_log.txt` file.
- Records all actions, results, and errors during script execution for easy review.

### **Administrative Privileges**
- Ensures the script is run with administrative privileges to perform critical system operations.

### **Critical Services Monitoring**
- Checks the status of essential Windows services like `wuauserv` (Windows Update) and `sppsvc` (Software Protection Service).

### **Diagnostic Operations**
- Optionally runs hardware diagnostics using built-in tools like `msdt.exe`.

### **Temporary Files Cleanup**
- Provides the option to delete temporary files, optimizing disk space.

### **DISM Commands**
- Executes a series of DISM commands for system health:
  - **CheckHealth**
  - **ScanHealth**
  - **StartComponentCleanup**
  - **RestoreHealth**
  - Optional **ResetBase** for deeper cleanup.

### **Network Reset**
- Resets network components, flushes DNS, and renews IP configurations for troubleshooting connectivity issues.

### **Event Log Management**
- Optionally clears Windows Event Logs to reduce clutter.

### **Driver Status Logging**
- Logs the current state of installed drivers using PowerShell.

### **Disk Cleanup**
- Runs Disk Cleanup with advanced options for system optimization.

### **System Restart**
- Prompts for a system restart to complete tasks requiring reboot.

---

## Prerequisites

- **Operating System**: Windows 10 or newer.
- **Administrator Privileges**: The script must be executed with elevated permissions.

---

## How to Use

1. **Download the Script**
   - Clone this repository or download the `windows-maintenance.bat` script directly.

2. **Run the Script**
   - Open a Command Prompt with administrative privileges.
   - Navigate to the directory containing the script.
   - Execute the script:
     ```cmd
     windows-maintenance.bat
     ```

3. **Follow the Prompts**
   - The script will prompt you for optional tasks like hardware diagnostics, temporary file cleanup, or event log clearing.
   - Respond with `Y` for yes or `N` for no. Default responses are set to `N` if no input is provided.

4. **Review Logs**
   - Maintenance logs are saved in the `logs` directory located alongside the script.
   - DISM logs can also be found at `C:\Windows\Logs\DISM\dism.log`.

---

## Customization

- **Log File Path**: Modify the `LOGFILE` and `LOGDIR` variables in the script to customize log locations.
- **Default Responses**: Change the default settings for prompts by editing the respective variables in the script (`set RUNHWDIAG=N`, `set DELTEMP=N`, etc.).
- **Additional Tasks**: Add or remove tasks to tailor the script to your specific maintenance needs.

---

## Example Log Output

Below is a snippet of what you can expect in the log file:

```text
[03/12/2024_14:00:00] Maintenance script started.
Checking for administrative privileges...
Administrative privileges confirmed.
Checking critical services...
Critical services status logged.
Running DISM operations...
DISM CheckHealth completed successfully.
DISM ScanHealth found no issues.
DISM RestoreHealth completed successfully.
...
[03/12/2024_14:15:00] Maintenance tasks completed. Check logs for details.
```

---

## Limitations

- Designed for advanced users; improper use may affect system stability.
- Requires administrative permissions for most operations.

---

## License

This script is provided under the MIT License. See the `LICENSE` file for details.

---

Feel free to reach out via issues or pull requests for improvements or additional features.
