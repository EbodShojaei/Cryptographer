#!/bin/bash

# Function to encrypt a string using alphanumeric characters
encrypt_string() {
    local string="$1"
    local password="$2"
    local encrypted_string=""

    # Encrypt the string using the password
    encrypted_string=$(echo "$string" | openssl enc -aes-256-cbc -a -salt -pbkdf2 -pass pass:"$password")

    echo "$encrypted_string"
}

# Function to decrypt a string that was encrypted using the encrypt_string function
decrypt_string() {
    local encrypted_string="$1"
    local password="$2"
    local decrypted_string=""

    # Decrypt the string using the password
    decrypted_string=$(echo "$encrypted_string" | openssl enc -d -aes-256-cbc -a -salt -pbkdf2 -pass pass:"$password")

    echo "$decrypted_string"
}

# Function to encrypt a file
encrypt_file() {
    local file="$1"
    local password="$2"
    local output_file="${3:-secret_file.enc}"

    # Ensure the output file has a .enc extension
    if [[ "$output_file" != *.enc ]]; then
        output_file="${output_file}.enc"
    fi

    # Check if the file is already encrypted
    if [[ "$file" == *.enc ]]; then
        echo "Error: The file '$file' is already encrypted."
        exit 1
    fi

    # Check if the file is a .txt file
    if [[ "$file" != *.txt ]]; then
        echo "Error: Only .txt files can be encrypted."
        exit 1
    fi

    # Check if the input is a directory
    if [ -d "$file" ]; then
        echo "Error: '$file' is a directory. Only files can be encrypted."
        exit 1
    fi

    if [ -f "$file" ]; then
        # Encrypt the file content
        openssl enc -aes-256-cbc -salt -pbkdf2 -in "$file" -out "$output_file" -k "$password"

        # Encrypt and prepend the file name and extension to the encrypted file
        local encrypted_name
        encrypted_name=$(encrypt_string "$file" "$password")
        echo "$encrypted_name" | cat - "$output_file" > temp && mv temp "$output_file"

        echo "File '$file' has been encrypted to '$output_file'."
    else
        echo "File '$file' does not exist."
    fi
}

# Function to decrypt a file
decrypt_file() {
    local file="$1"
    local password="$2"
    local output_file="${3:-secret_file}"

    # Check if the file is a .enc file
    if [[ "$file" != *.enc ]]; then
        echo "Error: The file '$file' is not an encrypted file."
        exit 1
    fi

    # Check if the input is a directory
    if [ -d "$file" ]; then
        echo "Error: '$file' is a directory. Only files can be decrypted."
        exit 1
    fi

    if [ -f "$file" ]; then
        # Extract the encrypted file name and extension
        local encrypted_name
        encrypted_name=$(head -n 1 "$file")

        # Decrypt the file name and extension
        local decrypted_name
        decrypted_name=$(decrypt_string "$encrypted_name" "$password")
        
        # If decryption of name is successful, use it; otherwise use the default name
        if [[ -n "$decrypted_name" ]]; then
            output_file="$decrypted_name"
        fi

        # Decrypt the rest of the file
        tail -n +2 "$file" | openssl enc -d -aes-256-cbc -salt -pbkdf2 -in /dev/stdin -out "$output_file" -k "$password"
        echo "File '$file' has been decrypted to '$output_file'."
    else
        echo "File '$file' does not exist."
    fi
}

# Main script logic
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <encrypt|decrypt> <file> <password> [output_file]"
    exit 1
fi

operation="$1"
file="$2"
password="$3"
output_file="$4"

case "$operation" in
    encrypt)
        encrypt_file "$file" "$password" "$output_file"
        ;;
    decrypt)
        decrypt_file "$file" "$password" "$output_file"
        ;;
    *)
        echo "Invalid operation: $operation"
        echo "Usage: $0 <encrypt|decrypt> <file> <password> [output_file]"
        exit 1
        ;;
esac
