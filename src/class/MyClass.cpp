#include "MyClass.h"

MyClass::MyClass(int value) : m_value(value) {
}

void MyClass::setValue(int value) {
    m_value = value;
}

int MyClass::getValue() const {
    return m_value;
}