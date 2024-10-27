import os
import cv2
from deepface import DeepFace
from datetime import datetime

def recognize_face(image_path, class_name):
    alunos_dir = f'models/alunos/{class_name}/'
    presenca_dir = 'presenca/'
    resultado = {}
    
    data_atual = datetime.now().strftime('%Y-%m-%d')
    arquivo_presenca = f'{presenca_dir}presenca_{class_name}_{data_atual}.txt'

    try:
        # Criação do diretório de presença, se não existir
        if not os.path.exists(presenca_dir):
            os.makedirs(presenca_dir)

        print(f"Image path: {image_path}")
        img = cv2.imread(image_path)
        if img is None:
            resultado['status'] = 'Erro ao carregar a imagem'
            return resultado

        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        # Carregar o classificador Haar Cascade
        face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5)

        print(f"Número de faces detectadas: {len(faces)}")

        if len(faces) == 0:
            resultado['status'] = 'Nenhuma face detectada'
            return resultado

        melhor_aluno = None
        maior_confianca = float('inf')

        # Verificar se o diretório dos alunos existe
        if not os.path.exists(alunos_dir):
            resultado['status'] = f'Pasta da classe "{class_name}" não encontrada'
            return resultado

        # Iterar sobre cada face detectada
        for (x, y, w, h) in faces:
            face = img[y:y+h, x:x+w]
            face_path = 'temp_face.jpg'
            cv2.imwrite(face_path, face)

            for aluno in os.listdir(alunos_dir):
                aluno_path = os.path.join(alunos_dir, aluno)
                print(f"Comparando com: {aluno_path}")

                try:
                    # Carregar a imagem do aluno para verificar se pode ser processada
                    aluno_img = cv2.imread(aluno_path)
                    if aluno_img is None:
                        raise ValueError(f"Erro ao carregar a imagem do aluno: {aluno_path}")

                    comparacao = DeepFace.verify(face_path, aluno_path, model_name='VGG-Face')

                    if comparacao['verified']:
                        confianca = comparacao['distance']
                        if confianca < maior_confianca:
                            melhor_aluno = aluno.split('.')[0]
                            maior_confianca = confianca
                except Exception as e:
                    print(f"Erro durante a verificação com {aluno_path}: {e}")

        if melhor_aluno:
            if maior_confianca < 0.4:
                resultado['status'] = 'Face reconhecida com alta confiança'
            elif 0.4 <= maior_confianca <= 0.6:
                resultado['status'] = 'Face reconhecida com confiança moderada'
            else:
                resultado['status'] = 'Face não reconhecida'

            resultado['aluno'] = melhor_aluno
            resultado['confiança'] = maior_confianca

            if maior_confianca < 0.6:
                with open(arquivo_presenca, 'a') as arquivo:
                    arquivo.write(f'Aluno: {melhor_aluno}, Confiança: {maior_confianca:.4f}\n')

        else:
            resultado['status'] = 'Face não reconhecida'
    except Exception as e:
        resultado['status'] = 'Erro no processamento'
        resultado['error'] = str(e)
        print(f"Error details: {e}")  # Print the error message to console

    return resultado
