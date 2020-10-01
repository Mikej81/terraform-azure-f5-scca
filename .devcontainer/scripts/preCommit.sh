  
#!/bin/bash
echo "---installing pre-commit---"
# pre commit
pip3 install --upgrade pip setuptools wheel
pip3 install pre-commit
pre-commit install
echo "---pre-commit done---"