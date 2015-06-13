nodemailer = require 'nodemailer'
smtpTransport = require 'nodemailer-smtp-transport'
mailerConfig = require('./config').services.mailer

module.exports = nodemailer.createTransport(smtpTransport(mailerConfig))
