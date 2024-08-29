from llama_index import VectorStoreIndex, SimpleDirectoryReader, ServiceContext
from llama_index.embeddings import resolve_embed_model
from llama_index.llms import Ollama

# Load documents from the specified directory
documents = SimpleDirectoryReader("chroma_data").load_data()

# Initialize the embedding model (bge-m3 model)
embed_model = resolve_embed_model("local:BAAI/bge-small-en-v1.5")

# Initialize the Ollama LLM with a specific model and request timeout
llm = Ollama(model="mistral", request_timeout=30.0)

# Create a service context with the embedding model and LLM
service_context = ServiceContext.from_defaults(
    embed_model=embed_model, llm=llm
)

# Create an index from the loaded documents and service context
index = VectorStoreIndex.from_documents(
    documents, service_context=service_context
)

# Create a query engine from the index
query_engine = index.as_query_engine()

# Query the engine and print the response
response = query_engine.query("What did the author do growing up?")
print(response)
