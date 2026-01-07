#!/bin/bash
kubectl taint nodes -l name=teemii-backend service-type=backend:NoSchedule
kubectl taint nodes -l name=teemii-frontend service-type=frontend:NoSchedule