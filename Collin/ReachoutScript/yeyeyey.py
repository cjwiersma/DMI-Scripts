
with open('text.txt', 'r') as fin:
    lines = [line.replace(' ', '.').strip('\n') + '@dmicorp.com\n' for line in fin]
with open('textout.txt', 'w') as fout:
    fout.writelines(lines)
