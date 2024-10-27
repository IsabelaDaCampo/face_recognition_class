
# Face Recognition Class

Programa em python que reconhece a face do aluno para adiciona-lo a chamada de uma aula.
## Índice

- [Descrição do Projeto](#descrição-do-projeto)
- [Funcionalidades](#funcionalidades)
- [Instalação](#instalação)
- [Uso](#uso)

## Descrição do Projeto

O `face_recognition_class` utiliza técnicas de visão computacional para detectar e reconhecer rostos em imagens.

## Funcionalidades

- Detecção e reconhecimento de rostos em imagens.
- Suporte a múltiplos formatos de imagem.
- Facilidade de integração em projetos existentes.

## Instalação

Para instalar o projeto, siga os passos abaixo:

1. **Clone o repositório:**

   ```bash
   git clone https://github.com/IsabelaDaCampo/face_recognition_class.git
   ```

2. **Navegue até o diretório do projeto:**

   ```bash
   cd face_recognition_class
   ```

3. **Crie um ambiente virtual (opcional, mas recomendado):**

   ```bash
   python -m venv venv
   source venv/bin/activate  # No Windows use: venv\Scripts\activate
   python app.py 
   ```

4. **Instale as dependências:**

   ```bash
   pip install -r requirements.txt
   ```

## Uso

Após a instalação, você pode usar a classe `FaceRecognition` para detectar e reconhecer rostos.

Utilizado em conjunto o frontend que é um aplicativo em Flutter que faz a chamada de uma aula e o backend que é um servidor em Flask que recebe a imagem do aluno e a compara com as imagens dos alunos cadastrados.
