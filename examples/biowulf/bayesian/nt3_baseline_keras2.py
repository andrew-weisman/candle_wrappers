import pandas as pd
import numpy as np
import os
import sys
import gzip

from keras import backend as K

from keras.layers import Input, Dense, Dropout, Activation, Conv1D, MaxPooling1D, Flatten
from keras.optimizers import SGD, Adam, RMSprop
from keras.models import Sequential, Model, model_from_json, model_from_yaml
from keras.utils import np_utils
from keras.callbacks import ModelCheckpoint, CSVLogger, ReduceLROnPlateau

from sklearn.metrics import accuracy_score
from sklearn.preprocessing import StandardScaler, MinMaxScaler, MaxAbsScaler

import sys, os
import candle

def load_data(train_path, test_path, candle_params):

    print('Loading data...')
    df_train = (pd.read_csv(train_path,header=None).values).astype('float32')
    df_test = (pd.read_csv(test_path,header=None).values).astype('float32')
    print('done')

    print('df_train shape:', df_train.shape)
    print('df_test shape:', df_test.shape)

    seqlen = df_train.shape[1]

    df_y_train = df_train[:,0].astype('int')
    df_y_test = df_test[:,0].astype('int')

    Y_train = np_utils.to_categorical(df_y_train,candle_params['classes'])
    Y_test = np_utils.to_categorical(df_y_test,candle_params['classes'])

    df_x_train = df_train[:, 1:seqlen].astype(np.float32)
    df_x_test = df_test[:, 1:seqlen].astype(np.float32)

    X_train = df_x_train
    X_test = df_x_test

    scaler = MaxAbsScaler()
    mat = np.concatenate((X_train, X_test), axis=0)
    mat = scaler.fit_transform(mat)

    X_train = mat[:X_train.shape[0], :]
    X_test = mat[X_train.shape[0]:, :]

    return X_train, Y_train, X_test, Y_test


print ('Params:', candle_params)

file_train = candle_params['train_data']
file_test = candle_params['test_data']
url = candle_params['data_url']

train_file = candle.get_file(file_train, url+file_train, datadir=os.getenv("CANDLE")+'/Benchmarks/Data/Pilot1')
test_file = candle.get_file(file_test, url+file_test, datadir=os.getenv("CANDLE")+'/Benchmarks/Data/Pilot1')

X_train, Y_train, X_test, Y_test = load_data(train_file, test_file, candle_params)

print('X_train shape:', X_train.shape)
print('X_test shape:', X_test.shape)

print('Y_train shape:', Y_train.shape)
print('Y_test shape:', Y_test.shape)

x_train_len = X_train.shape[1]

# this reshaping is critical for the Conv1D to work

X_train = np.expand_dims(X_train, axis=2)
X_test = np.expand_dims(X_test, axis=2)

print('X_train shape:', X_train.shape)
print('X_test shape:', X_test.shape)

model = Sequential()

layer_list = list(range(0, len(candle_params['conv']), 3))
for l, i in enumerate(layer_list):
    filters = candle_params['conv'][i]
    filter_len = candle_params['conv'][i+1]
    stride = candle_params['conv'][i+2]
    print(int(i/3), filters, filter_len, stride)
    if candle_params['pool']:
        pool_list=candle_params['pool']
        if type(pool_list) != list:
            pool_list=list(pool_list)

    if filters <= 0 or filter_len <= 0 or stride <= 0:
            break
    if 'locally_connected' in candle_params:
            model.add(LocallyConnected1D(filters, filter_len, strides=stride, padding='valid', input_shape=(x_train_len, 1)))
    else:
        #input layer
        if i == 0:
            model.add(Conv1D(filters=filters, kernel_size=filter_len, strides=stride, padding='valid', input_shape=(x_train_len, 1)))
        else:
            model.add(Conv1D(filters=filters, kernel_size=filter_len, strides=stride, padding='valid'))
    model.add(Activation(candle_params['activation']))
    if candle_params['pool']:
            model.add(MaxPooling1D(pool_size=pool_list[int(i/3)]))

model.add(Flatten())

for layer in candle_params['dense']:
    if layer:
        model.add(Dense(layer))
        model.add(Activation(candle_params['activation']))
        if candle_params['drop']:
                model.add(Dropout(candle_params['drop']))
model.add(Dense(candle_params['classes']))
model.add(Activation(candle_params['out_act']))

#Reference case
#model.add(Conv1D(filters=128, kernel_size=20, strides=1, padding='valid', input_shape=(P, 1)))
#model.add(Activation('relu'))
#model.add(MaxPooling1D(pool_size=1))
#model.add(Conv1D(filters=128, kernel_size=10, strides=1, padding='valid'))
#model.add(Activation('relu'))
#model.add(MaxPooling1D(pool_size=10))
#model.add(Flatten())
#model.add(Dense(200))
#model.add(Activation('relu'))
#model.add(Dropout(0.1))
#model.add(Dense(20))
#model.add(Activation('relu'))
#model.add(Dropout(0.1))
#model.add(Dense(CLASSES))
#model.add(Activation('softmax'))

kerasDefaults = candle.keras_default_config()

# Define optimizer
optimizer = candle.build_optimizer(candle_params['optimizer'],
                                            candle_params['learning_rate'],
                                            kerasDefaults)

model.summary()
model.compile(loss=candle_params['loss'],
                optimizer=optimizer,
                metrics=[candle_params['metrics']])

output_dir = candle_params['save']

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# calculate trainable and non-trainable params
candle_params.update(candle.compute_trainable_params(model))

# set up a bunch of callbacks to do work during model training..
model_name = candle_params['model_name']
path = '{}/{}.autosave.model.h5'.format(output_dir, model_name)
csv_logger = CSVLogger('{}/training.log'.format(output_dir))
reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.1, patience=10, verbose=1, mode='auto', epsilon=0.0001, cooldown=0, min_lr=0)
candleRemoteMonitor = candle.CandleRemoteMonitor(params=candle_params)
timeoutMonitor = candle.TerminateOnTimeOut(candle_params['timeout'])

history2 = model.fit(X_train, Y_train,
                batch_size=candle_params['batch_size'],
                epochs=candle_params['epochs'],
                verbose=1,
                validation_data=(X_test, Y_test),
                callbacks = [csv_logger, reduce_lr, candleRemoteMonitor, timeoutMonitor])

score = model.evaluate(X_test, Y_test, verbose=0)

candle_value_to_return = score[0]

print(model.metrics_names)
print(score)
