# Cryptographer

This program is a compiled bash script for encrypting/decrypting text files (.txt) with a custom password using a command-line interface.

## Usage

Make sure to use the following code to authorize execution of the script on your machine.

```bash
chmod +x ./crypto.sh
```

Use the following parameters when running the script.

```bash
Usage: ./crypto.sh <encrypt|decrypt> <file> <password> [output_file]"
```

### Example

```bash
❯ ./crypto.sh encrypt input.txt 123456789 output
File 'input.txt' has been encrypted to 'output.enc'.
❯ ./crypto.sh decrypt output.enc 123456789
File 'output.enc' has been decrypted to 'input.txt'.
```

\*\* Note that the `output_file` is an optional parameter that defaults to `secret_file.enc` as the name of the encrypted output file.

## Acknowledgements

By using this script, the user understands that the author is not responsible for any loss of data or any other unintended damages to the system.
