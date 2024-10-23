import os
import cv2

def salvar_foto_aluno(image_path, aluno_nome):
    alunos_dir = 'models/alunos/'

    if not os.path.exists(alunos_dir):
        os.makedirs(alunos_dir)

    img = cv2.imread(image_path)
    
    if img is None:
        return {'status': 'Falha ao carregar a imagem'}

    aluno_foto_path = os.path.join(alunos_dir, f'{aluno_nome}.jpg')

    cv2.imwrite(aluno_foto_path, img)

    return {'status': 'Foto salva com sucesso', 'path': aluno_foto_path}
