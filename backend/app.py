from flask import Flask, request, jsonify
import os
from werkzeug.utils import secure_filename
from utils.face_recognition import reconhecer_face
from utils.save_student import salvar_foto_aluno

app = Flask(__name__)

# Configuração da pasta de upload
UPLOAD_FOLDER = 'uploads/'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/api/recognize', methods=['POST'])
def upload_image():
    if 'image' not in request.files:
        return jsonify({'error': 'Nenhuma imagem enviada'}), 400

    file = request.files['image']

    if file.filename == '':
        return jsonify({'error': 'Nenhum arquivo selecionado'}), 400

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        # Realiza o reconhecimento facial
        resultado = reconhecer_face(filepath)

        return jsonify(resultado), 200
    else:
        return jsonify({'error': 'Formato de arquivo inválido'}), 400
    
@app.route('/api/save-student', methods=['POST'])
def salvar_aluno():
    if 'image' not in request.files or 'name' not in request.form:
        return jsonify({'error': 'Imagem ou nome do aluno não fornecido'}), 400

    file = request.files['image']
    name = request.form['name']

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        # Salva a foto do aluno
        resultado = salvar_foto_aluno(filepath, name)

        return jsonify(resultado), 200
    else:
        return jsonify({'error': 'Formato de arquivo inválido'}), 400


if __name__ == '__main__':
    if not os.path.exists(app.config['UPLOAD_FOLDER']):
        os.makedirs(app.config['UPLOAD_FOLDER'])
    app.run(debug=True)
