from chromadb import Documents, EmbeddingFunction, Embeddings
from transformers import AutoTokenizer, AutoModel
import torch

class LlamaEmbeddingFunction(EmbeddingFunction):
    def __init__(self, model_name: str):
        # Load the tokenizer and model from the HuggingFace Transformers library
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModel.from_pretrained(model_name)
    
    def __call__(self, input: Documents) -> Embeddings:
        # Tokenize the input documents
        inputs = self.tokenizer(input, return_tensors='pt', padding=True, truncation=True)
        # Generate embeddings using the model
        with torch.no_grad():
            outputs = self.model(**inputs)
        # The embeddings are typically taken from the last hidden state
        embeddings = outputs.last_hidden_state.mean(dim=1)
        return embeddings.cpu().numpy()
