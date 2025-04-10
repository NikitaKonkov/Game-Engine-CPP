#ifndef MYCLASS_H
#define MYCLASS_H

class MyClass {
private:
    int m_value;
public:
    MyClass(int value);
    void setValue(int value);
    int getValue() const;
};

#endif // MYCLASS_H