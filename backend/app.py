from flask import Flask, request, jsonify
import os
from werkzeug.utils import secure_filename
from datetime import datetime
from utils.face_recognition import recognize_face
from utils.save_student import save_student_picture
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = 'uploads/'
PRESENCA_FOLDER = 'presenca/'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['PRESENCA_FOLDER'] = PRESENCA_FOLDER

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/api/recognize', methods=['POST'])
def upload_image():
    if 'image' not in request.files and 'class' not in request.form:
        return jsonify({'error': 'Imagem e classe não fornecidas'}), 400

    file = request.files['image']
    class_name = request.form['class']

    if file.filename == '':
        return jsonify({'error': 'Nenhum arquivo selecionado'}), 400

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        resultado = recognize_face(filepath, class_name)

        return jsonify(resultado), 200
    else:
        return jsonify({'error': 'Formato de arquivo inválido'}), 400
    
@app.route('/api/save-student', methods=['POST'])
def salvar_aluno():
    if 'image' not in request.files or 'name' not in request.form or 'class' not in request.form:
        return jsonify({'error': 'Imagem, nome ou classe do aluno não fornecido'}), 400

    file = request.files['image']
    name = request.form['name']
    class_name = request.form['class']

    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        resultado = save_student_picture(filepath, name, class_name)

        return jsonify(resultado), 200
    else:
        return jsonify({'error': 'Formato de arquivo inválido'}), 400

@app.route('/api/presences', methods=['GET'])
def listar_presencas():
    data_atual = request.args.get('date', datetime.now().strftime('%Y-%m-%d'))
    pasta_presenca = app.config['PRESENCA_FOLDER']

    try:
        arquivos_presenca = os.listdir(pasta_presenca)
        print(f"Arquivos encontrados na pasta: {arquivos_presenca}")
    except Exception as e:
        print(f"Erro ao listar arquivos na pasta {pasta_presenca}: {str(e)}")
        return jsonify({'error': 'Erro ao acessar a pasta de presenças', 'details': str(e)}), 500

    arquivos_filtrados = [f for f in arquivos_presenca 
                          if f.startswith('presenca_') and f.endswith(f'_{data_atual}.txt')]

    if not arquivos_filtrados:
        return jsonify({'error': f'Nenhum arquivo de presença encontrado para a data "{data_atual}"'}), 404

    presencas = []
    for arquivo in arquivos_filtrados:
        try:
            with open(os.path.join(pasta_presenca, arquivo), 'r') as file:
                conteudo = file.readlines()

            presencas_unicas = set(p.strip() for p in conteudo)

            nome_classe = arquivo.split('_')[1]
            presencas.append({
                'class': nome_classe,
                'date': data_atual,
                'presences': list(presencas_unicas)
            })

            print(f"Presenças lidas do arquivo {arquivo} (sem duplicatas): {presencas_unicas}")

        except Exception as e:
            print(f"Erro ao ler o arquivo {arquivo}: {str(e)}")
            return jsonify({'error': f'Erro ao ler o arquivo "{arquivo}"', 'details': str(e)}), 500

    return jsonify(presencas), 200


if __name__ == '__main__':
    if not os.path.exists(app.config['UPLOAD_FOLDER']):
        os.makedirs(app.config['UPLOAD_FOLDER'])
    if not os.path.exists(app.config['PRESENCA_FOLDER']):
        os.makedirs(app.config['PRESENCA_FOLDER'])
app.run(host='0.0.0.0', port=5000, debug=True)
