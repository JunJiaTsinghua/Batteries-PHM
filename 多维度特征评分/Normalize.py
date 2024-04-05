def normalize(list):
    Max = max(list)
    list_norm = [i / Max for i in list]
    return list_norm
