import faiss

def load_database():
    index = faiss.read_index('data_beta1.faiss')
    return index
