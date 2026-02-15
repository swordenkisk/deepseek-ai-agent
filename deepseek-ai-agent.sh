#!/bin/bash
# deepseek-ai-agent.sh - Full-featured DeepSeek AI Agent
# Usage: ./deepseek-ai-agent.sh "your question" or run without args for interactive mode

# Load variables from .env
set -a
[ -f .env ] && source .env
set +a

# Check for API Key
if [ -z "$DEEPSEEK_API_KEY" ]; then
    echo "❌ Error: DEEPSEEK_API_KEY must be set in .env file"
    echo "Example .env:"
    echo "DEEPSEEK_API_KEY=sk-xxxxxxxxxxxxxxxxxxxx"
    exit 1
fi

# Default settings
MODEL="${DEEPSEEK_MODEL:-deepseek-chat}"
MAX_TOKENS="${MAX_TOKENS:-4096}"
TEMPERATURE="${TEMPERATURE:-0.7}"

# Helper functions
show_help() {
    echo "🤖 Full-featured DeepSeek AI Agent"
    echo ""
    echo "Usage:"
    echo "  ./deepseek-ai-agent.sh \"your question here\""
    echo "  ./deepseek-ai-agent.sh          # interactive mode"
    echo "  ./deepseek-ai-agent.sh -m deepseek-coder \"code\""
    echo ""
    echo "Options:"
    echo "  -m, --model MODEL      Model (deepseek-chat, deepseek-coder)"
    echo "  -t, --tokens NUM       Max tokens"
    echo "  -T, --temperature NUM  Temperature (0.0-2.0)"
    echo "  -h, --help            Show help"
    echo ""
    echo "Example .env:"
    echo "DEEPSEEK_API_KEY=sk-xxxxxxxxxxxx"
    echo "DEEPSEEK_MODEL=deepseek-chat"
}

# API request function
send_request() {
    local prompt="$1"
    curl -s -X POST "https://api.deepseek.com/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
        -d "{
            \"model\": \"$MODEL\",
            \"messages\": [
                {\"role\": \"system\", \"content\": \"You are an advanced intelligent assistant. Provide accurate and helpful responses.\"},
                {\"role\": \"user\", \"content\": \"$prompt\"}
            ],
            \"max_tokens\": $MAX_TOKENS,
            \"temperature\": $TEMPERATURE,
            \"stream\": false
        }" | jq -r '.choices[0].message.content // "❌ Response error"'
}

# Interactive mode
interactive_mode() {
    echo "🚀 DeepSeek AI Interactive Mode (Ctrl+C to exit)"
    echo "─────────────────────────────────────"
    while true; do
        echo -n "💭 Your question: "
        read -r input
        [ -z "$input" ] && continue
        
        echo "🤖 DeepSeek:"
        send_request "$input"
        echo "─────────────────────────────────────"
    done
}

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--model)
            MODEL="$2"
            shift 2
            ;;
        -t|--tokens)
            MAX_TOKENS="$2"
            shift 2
            ;;
        -T|--temperature)
            TEMPERATURE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# Main execution
if [ $# -eq 0 ]; then
    interactive_mode
else
    echo "🤖 DeepSeek: $MODEL"
    send_request "$*"
fi
