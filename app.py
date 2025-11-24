from flask import Flask, request, jsonify
from src import main  # import functions from your main.py

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello! Flask app is running.", 200

@app.route('/add', methods=['GET'])
def add():
    try:
        # Use main.py logic if you have a function called add
        a = float(request.args.get('a', 0))
        b = float(request.args.get('b', 0))
        
        # If main.py has a function add(a,b), call it; otherwise just sum
        if hasattr(main, "add"):
            result = main.add(a, b)
        else:
            result = a + b
        
        return jsonify({'result': result})
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
