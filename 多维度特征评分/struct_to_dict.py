
def struct_to_dict(father_key,target_object):
    target_object=target_object[father_key]#从上一层来的对象，要被更新。既然能来这里，肯定是有key的
    data={}
    # print(father_key)
    try:
        son_keys=list(target_object.keys())
        for son_key in son_keys:
            # print(son_key)
            this_data_to_judge=struct_to_dict(son_key,target_object)
            data[son_key] = this_data_to_judge
    except BaseException:
        # data=target_object
        data=list(target_object[()].flatten())
    return data 