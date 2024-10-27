import os
import cv2

def save_student_picture(image_path, student_name, student_class):
    alunos_dir = 'models/alunos/'

    class_dir = os.path.join(alunos_dir, student_class)
    if not os.path.exists(class_dir):
        os.makedirs(class_dir)

    img = cv2.imread(image_path)
    
    if img is None:
        return {'status': 'Falha ao carregar a imagem'}

    aluno_foto_base = f'{student_name}_{student_class}'
    
    contador = 1
    while True:
        aluno_foto_path = os.path.join(class_dir, f'{aluno_foto_base}_{contador}.jpg')
        if not os.path.exists(aluno_foto_path):
            break
        contador += 1

    cv2.imwrite(aluno_foto_path, img)

    return {'status': 'Foto salva com sucesso', 'path': aluno_foto_path}
