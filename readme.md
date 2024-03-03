# GOEnum
### A Bash Auto Enumeration Script that uses Go Tools to Enumerate. 

This script is inspired by TCM Security and "Sumrecon," enhancing a Practical Ethical Hacking tutorial. It optimizes directory structures, uses Variables set by [Project_Setup](https://github.com/CyberLocc/Project_Setup) . It introduces a toggle for Amass usage and prompts for domain input, prioritizing user-friendliness. Ascii art adds flair. Development on this project is ongoing.

## Usage

To use the script, simply run it from the command line. Optionally, you can provide a target URL as an argument. If no URL is provided, the script will prompt you to enter one.

Example:  
```./script.sh example.com```

## Installation

Before using the script, ensure you have the necessary dependencies installed, including GoLang and various tools like assetfinder, amass, httprobe, waybackurls, and gowitness. If any of these tools are missing, the script will provide instructions for installing them.

## Examples

### Example 1: Basic Usage
```./script.sh example.com```


### Example 2: Running with Amass
```./script.sh example.com```

When prompted, choose to run Amass commands.

## Troubleshooting

If you encounter any issues while using the script, please check the following:

- Ensure all dependencies are properly installed.
- Verify that you have provided the correct input when prompted.
- Check for any error messages displayed during script execution.

## Contributing

Contributions to this project are welcome! If you have any suggestions for improvements or would like to report a bug, please open an issue on the GitHub repository. Pull requests are also encouraged.

## License
This script is released under the MIT License.
