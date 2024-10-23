import os
import cv2
from deepface import DeepFace

def reconhecer_face(image_path):
    alunos_dir = 'models/alunos/'
    resultado = {}

    try:
        # Carregar a imagem usando OpenCV
        img = cv2.imread(image_path)
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        # Carregar o classificador Haarcascade para detecção de faces
        face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5)

        if len(faces) == 0:
            resultado['status'] = 'Nenhuma face detectada'
            return resultado

        # Variáveis para armazenar a melhor correspondência
        melhor_aluno = None
        maior_confianca = 0.0  # Confiabilidade da correspondência

        # Loop para reconhecer a face detectada
        for (x, y, w, h) in faces:
            face = img[y:y+h, x:x+w]
            face_path = 'temp_face.jpg'
            cv2.imwrite(face_path, face)  # Salvar face detectada temporariamente

            for aluno in os.listdir(alunos_dir):
                aluno_path = os.path.join(alunos_dir, aluno)
                comparacao = DeepFace.verify(face_path, aluno_path, model_name='VGG-Face')

                # Verificar se a face foi reconhecida e coletar a confiança
                if comparacao['verified']:
                    confianca = comparacao['distance']  # A distância é uma métrica de confiança
                    if melhor_aluno is None or confianca < maior_confianca:
                        melhor_aluno = aluno.split('.')[0]  # Nome do aluno sem a extensão
                        maior_confianca = confianca

        # Verifica se encontramos uma melhor correspondência
        if melhor_aluno:
            resultado['status'] = 'Face reconhecida'
            resultado['aluno'] = melhor_aluno
            resultado['confiança'] = maior_confianca
        else:
            resultado['status'] = 'Face não reconhecida'
    except Exception as e:
        resultado['status'] = 'Erro no processamento'
        resultado['error'] = str(e)

    return resultado
