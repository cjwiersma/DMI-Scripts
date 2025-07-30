
def reachout() -> None:
    import pyperclip

    name: str = input('name - ')
    problem: str = input('I have a ticket you opened about... '
                         '')

    s1 = f'Hi {name.capitalize()} I have a ticket opened about {problem}, have a moment to look at this?'
    pyperclip.copy(s1)

    def yum():
        e = input('1 - phone number\n2 - connect\n3 - control\nx - exit\n-----------\n')
        if e == '1':
            s2: str = 'Whats a good number to reach you at?'
            pyperclip.copy(s2)
            return yum()

        elif e == '2':
            s3: str = 'Give me one moment to connect to your computer'
            pyperclip.copy(s3)
            return yum()

        elif e == '3':
            s4: str = 'Can I take control?'
            pyperclip.copy(s4)
            return yum()
        elif e == 'x':
            return reachout()

        else:
            print('#########\nnot an option\n#########')
            return yum()
    yum()

if __name__ == '__main__':
    reachout()
