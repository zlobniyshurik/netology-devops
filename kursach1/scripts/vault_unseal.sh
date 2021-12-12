#!/usr/bin/env bash

#################################################################
# Разлочиваем хранилище содержимым первых трех файлов с ключами #
#                                                               #
# Ключи лежат в файлах vaultkeys/*.key                          #
#################################################################

#задаём метод доступа и адрес волта
export VAULT_ADDR='http://127.0.0.1:8200'

#пытаемся разлочить волт первыми тремя ключами
vault operator unseal $(cat vaultkeys/1.key)
vault operator unseal $(cat vaultkeys/2.key)
vault operator unseal $(cat vaultkeys/3.key)

