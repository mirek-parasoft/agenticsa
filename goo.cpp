#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <stdlib.h>  
#include <string.h>  

volatile uint16_t SENSOR_DATA = 0;
volatile uint16_t MOTOR_SPEED = 0;

volatile uint16_t SENSOR_HIGH_THRESHOLD = 500;
volatile uint16_t SENSOR_LOW_THRESHOLD = 100;
volatile uint16_t DEFAULT_VALUE = 10;
volatile uint16_t MULTIPLIER = 2;


uint16_t readSensor()
{
    return SENSOR_DATA; 
}

void setMotorSpeed(uint16_t speed)
{
    MOTOR_SPEED = speed;
}

int computeControl(int sensor, int divisor)
{
    if (sensor > SENSOR_HIGH_THRESHOLD) {
        return sensor / divisor;
    } else if (sensor > SENSOR_LOW_THRESHOLD) {
        return sensor * MULTIPLIER;
    } else {
        return DEFAULT_VALUE;
    }
}

int processCommand(const char* cmd, const char* arg)
{
    if (strcmp(cmd, "SET") == 0) {
        char* endptr = NULL;
        long parsed = 0;

        errno = 0;
        parsed = strtol(arg, &endptr, 10);

        if ((errno != 0) || (endptr == arg) || (*endptr != '\0') || (parsed < 0) || (parsed > UINT16_MAX)) {
            return -1;
        }

        setMotorSpeed((uint16_t)parsed);
        return (int)parsed;
    }

    if (strcmp(cmd, "READ") == 0) {
        return readSensor();
    }
    return -1; 
}

int processor(char* cmd, char* arg)
{
    uint16_t sensor = readSensor();
    int control = computeControl(sensor, 0); 
    return processCommand(cmd, arg) + control;
}