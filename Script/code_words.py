#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
导出代码中的单词
"""

import json
import re
import os

INPUT_FILE = '/Users/mayong/Desktop/My/DSBridge-iOS/Script/Eggy_strings_20250704_112919.txt'  # 输入文件，包含要提取单词的代码
INPUT_DIRECTORY = '../DSBridge/Core'  # 输入目录，包含要提取单词的代码文件
OUTPUT_DIRECTORY = './Output/'  # 输出目录，存储提取的单词

def ensure_output_directory():
    """确保输出目录存在"""
    if not os.path.exists(OUTPUT_DIRECTORY):
        os.makedirs(OUTPUT_DIRECTORY)
        print(f"✅ 输出目录 '{OUTPUT_DIRECTORY}' 已创建")
    else:
        print(f"✅ 输出目录 '{OUTPUT_DIRECTORY}' 已存在")
        
def write_words_to_file(words, output_file):
    """将提取的单词写入文件"""
    with open(output_file, 'w', encoding='utf-8') as f:
        if isinstance(words, dict):
            # 按照出现次数排序，次数多的排在前面
            sorted_words = sorted(words.items(), key=lambda x: x[1]['count'], reverse=True)
            for word_key, word_data in sorted_words:
                f.write(f"{word_data['word']}: {word_data['count']}\n")
        else:
            # 如果是列表或其他可迭代对象
            for word in words:
                f.write(f"{word}\n")
    print(f"📄 单词已写入文件：{output_file}")
        
def extract_words_from_directory(directory):
    """从指定目录中的所有代码文件中提取单词"""
    # words = set()
    word_map = {}

    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.h') or file.endswith('.m') or file.endswith('.swift'):
                file_path = os.path.join(root, file)
                print(f"📄 正在处理文件：{file_path}")
                file_words = extract_words_from_code(file_path)
                for key in file_words: 
                    word_object = file_words[key]
                    word = word_object['word']
                    count = word_object['count']
                    # 统一转换为小写
                    word_object = word_map.get(word.lower(), {'word': word, 'count': 0})
                    word_object['count'] += count
                    word_map[word.lower()] = word_object

    return word_map

def split_camel_case(text):
    """将驼峰命名法的字符串分割成单词列表"""
    # 使用正则表达式分割驼峰命名
    # (?<=[a-z])(?=[A-Z]) 匹配小写字母后跟大写字母的位置
    # (?<=[A-Z])(?=[A-Z][a-z]) 匹配大写字母后跟大写字母+小写字母的位置（处理连续大写字母）
    words = re.sub(r'(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])', ' ', text).split()
    return [word for word in words if word]

def extract_words_from_string(code_string):
    """从代码字符串中提取单词"""
    # 统计单词出现的次数
    word_map = {}
    # 使用正则表达式提取单词
    # 匹配标识符：字母开头，后跟字母、数字或下划线
    words = re.findall(r'[a-zA-Z][a-zA-Z0-9_]*', code_string)
    
    # 使用_和驼峰分隔字符串
    for word in words:
        # 处理驼峰命名和下划线分隔
        parts = re.split(r'[_]+', word)
        for part in parts:
            # 分割驼峰命名
            camel_case_words = split_camel_case(part)
            for camel_word in camel_case_words:
                # 统一转换为小写
                word_object = word_map.get(camel_word.lower(), {'word': camel_word, 'count': 0})
                word_object['count'] += 1
                word_map[camel_word.lower()] = word_object
    # 返回排序后的单词列表
    return word_map

def extract_words_from_code(file_path):
    """从代码文件中提取单词"""
    if not os.path.exists(file_path):
        print(f"❌ 错误：文件 '{file_path}' 不存在")
        return []

    word_map = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            # 使用正则表达式提取单词
            file_words = extract_words_from_string(line)
            for key in file_words:
                word = file_words[key]
                # 统一转换为小写
                word_object = word_map.get(word['word'].lower(), {'word': word['word'], 'count': 0})
                word_object['count'] += word['count']
                word_map[word['word'].lower()] = word_object

    return word_map

if __name__ == "__main__":
    ensure_output_directory()
    # words = extract_words_from_directory(INPUT_DIRECTORY)
    words = extract_words_from_code(INPUT_FILE)
    output_file = os.path.join(OUTPUT_DIRECTORY, 'Eggy_Strings_no.txt')
    print(words)
    write_words_to_file(words, output_file)
