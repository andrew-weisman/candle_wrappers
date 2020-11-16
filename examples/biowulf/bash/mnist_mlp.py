##########################################
# Your DL start here. See mnist_mlp.py   #
##########################################
'''Trains a simple deep NN on the MNIST dataset.

Gets to 98.40% test accuracy after 20 epochs
(there is *a lot* of margin for parameter tuning).
2 seconds per epoch on a K520 GPU.
'''

import argparse

def run_mnist(batch_size, epochs, activation, optimizer):
    import keras
    from keras.datasets import mnist
    from keras.models import Sequential
    from keras.layers import Dense, Dropout
    from keras.optimizers import RMSprop


    """
        Train a deep learning model on MNIST. 

        Arguments:
            batch_size: int
                The size of the batch in one step
            epochs: int
                Total number of epochs to run
            activation: string
                The activation function of the neurons
            optimizer: string
                Optimizer to update weights
        returns: (loss, accuracy)
    
    """

    num_classes = 10

    # the data, split between train and test sets
    (x_train, y_train), (x_test, y_test) = mnist.load_data()
    
    x_train = x_train.reshape(60000, 784)
    x_test = x_test.reshape(10000, 784)
    x_train = x_train.astype('float32')
    x_test = x_test.astype('float32')
    x_train /= 255
    x_test /= 255
    print(x_train.shape[0], 'train samples')
    print(x_test.shape[0], 'test samples')
    
    # convert class vectors to binary class matrices
    y_train = keras.utils.to_categorical(y_train, num_classes)
    y_test = keras.utils.to_categorical(y_test, num_classes)
    
    model = Sequential()
    model.add(Dense(512, activation=activation, input_shape=(784,)))
    model.add(Dropout(0.2))
    model.add(Dense(512, activation=activation))
    model.add(Dropout(0.2))
    model.add(Dense(num_classes, activation='softmax'))
    
    model.summary()
    
    model.compile(loss='categorical_crossentropy',
                optimizer=optimizer,
                metrics=['accuracy'])
    
    history = model.fit(x_train, y_train,
                        batch_size=batch_size,
                        epochs=epochs,
                        verbose=1,
                        validation_data=(x_test, y_test))
    score = model.evaluate(x_test, y_test, verbose=0)
    print('Test loss:', score[0])
    print('Test accuracy:', score[1])
    return score
    ##########################################
    # End of mnist_mlp.py ####################
    ##########################################


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Train a deep learning on MNIST data')
    parser.add_argument('--batch_size', type=int, default=128, help='The size of the batch in one step')
    parser.add_argument('--epochs', type=int, default=2, help='The size of the batch in one step')
    parser.add_argument('--activation', default="relu", help='The activation function of the neurons')
    parser.add_argument('--optimizer', default="rmsprop", help='Optimizer to update weights')
    args = parser.parse_args()
    
    scores = run_mnist(args.batch_size, args.epochs, args.activation, args.optimizer)

    #Return score using files 
    with open ("results.txt", 'w') as result:
        result.write(str(scores[0]))
