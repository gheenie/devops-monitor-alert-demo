from random import randint
import logging

logger = logging.getLogger('MistakerLogger')
logger.setLevel(logging.INFO)


class MultipleOfFiveError(Exception):
    pass


def lambda_handler(event, context):
    number = randint(1, 100)
    if number % 5 == 0:
        logger.warning(f'Oh no {number} is divisible by 5')
        raise MultipleOfFiveError
    else:
        logger.info(f'Yawn. {number} is a pretty boring number')
