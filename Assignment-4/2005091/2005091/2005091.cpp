#include <bits/stdc++.h>
#include <pthread.h>
#include <semaphore.h>
using namespace std;
int N,M,w,x,y,z,readerCount=0,writerCount=0;
mt19937 rnd(time(0));

sem_t gallery1_sem;
sem_t corridor_sem;
pthread_mutex_t inPhotoBooth;
pthread_mutex_t step_mtx[3];
pthread_mutex_t isPrintingOk;
pthread_mutex_t photoBoothAccess;
pthread_mutex_t readerCounter_lock;
pthread_mutex_t writerCounter_lock;


int get_random_number()
{
  random_device rd;
  mt19937 Rnd(rd());
  double lambda=10000.234;
  poisson_distribution<int>poissonDist(lambda);
  return poissonDist(Rnd);
}
void exactSleepInSec(int timeInSec) 
{
    usleep(timeInSec*1000000);
}

void randomSleep_1_To_3_Sec()
{
    usleep((rnd()%300+100)*10000);
}

timespec startingOfProcess;
timespec currentTimeOfProcess;
long long timeDifference(){
    return currentTimeOfProcess.tv_sec-startingOfProcess.tv_sec;
}
void printLog(string s,int visitor_id,int timeOfThisStep)
{
    pthread_mutex_lock(&isPrintingOk);
    clock_gettime(CLOCK_MONOTONIC,&currentTimeOfProcess);
    cout<<"Visitor "<<visitor_id<<" "<<s<<" at timestamp "<<timeDifference()<<endl;
    pthread_mutex_unlock(&isPrintingOk);
}


void reader_standard(int visitor_id) 
{
    pthread_mutex_lock(&photoBoothAccess);

    pthread_mutex_lock(&readerCounter_lock);
    readerCount++;
    if(readerCount==1)pthread_mutex_lock(&inPhotoBooth);
    pthread_mutex_unlock(&readerCounter_lock);

    pthread_mutex_unlock(&photoBoothAccess);

    printLog("is inside the photo booth",visitor_id,0);

    exactSleepInSec(z);

    printLog("left the photo booth",visitor_id,0);


    pthread_mutex_lock(&readerCounter_lock);
    readerCount--;
    if(readerCount==0)pthread_mutex_unlock(&inPhotoBooth);
    pthread_mutex_unlock(&readerCounter_lock);
    return;
}


void writer_premium(int visitor_id)
{
    pthread_mutex_lock(&writerCounter_lock);
    writerCount++;
    if(writerCount==1)pthread_mutex_lock(&photoBoothAccess);
    pthread_mutex_unlock(&writerCounter_lock);

    pthread_mutex_lock(&inPhotoBooth);

    printLog("is inside the photo booth",visitor_id,0);
    exactSleepInSec(z);
    printLog("left the photo booth",visitor_id,0);

    pthread_mutex_unlock(&inPhotoBooth);

    pthread_mutex_lock(&writerCounter_lock);
    writerCount--;
    if(writerCount==0)pthread_mutex_unlock(&photoBoothAccess);
    pthread_mutex_unlock(&writerCounter_lock);
    return;
}


void* visitor(void* arg)
{
    randomSleep_1_To_3_Sec();
    int visitor_id=*(int*)arg;

    printLog("has arrived at A",visitor_id,0);

    exactSleepInSec(w);

    printLog("has arrived at B",visitor_id,0);

    pthread_mutex_lock(&step_mtx[0]);
    printLog("is at step 1",visitor_id,0);
    randomSleep_1_To_3_Sec();

    pthread_mutex_lock(&step_mtx[1]);
    printLog("is at step 2",visitor_id,0);
    pthread_mutex_unlock(&step_mtx[0]);
    randomSleep_1_To_3_Sec();

    pthread_mutex_lock(&step_mtx[2]);
    printLog("is at step 3",visitor_id,0);
    pthread_mutex_unlock(&step_mtx[1]);
    randomSleep_1_To_3_Sec();

    sem_wait(&gallery1_sem);
    printLog("is at C (entered Gallery 1)",visitor_id,0);
    pthread_mutex_unlock(&step_mtx[2]);
    exactSleepInSec(x);

    
    sem_wait(&corridor_sem);
    
    printLog("is at D ((exiting Gallery 1)",visitor_id,0);
    printLog("is in Glass Corridor",visitor_id,0);

    
    sem_post(&gallery1_sem);
    randomSleep_1_To_3_Sec();
    sem_post(&corridor_sem);
    
    printLog("left Glass Corridor",visitor_id,0);


    ////////////////////////////////////////
    printLog("is at E (entered Gallery 2)",visitor_id,0);

    exactSleepInSec(y);
    randomSleep_1_To_3_Sec();

    printLog("is about to enter the photo booth",visitor_id,0);

    if(visitor_id<2001)
    {
        reader_standard(visitor_id);
    }
    else writer_premium(visitor_id);

    printLog("left gallery 2",visitor_id,0);

    return NULL;
}

int main() 
{
    cin>>N>>M>>w>>x>>y>>z;
    clock_gettime(CLOCK_MONOTONIC,&startingOfProcess);
    
    sem_init(&gallery1_sem,0,5);
    sem_init(&corridor_sem,0,3);

    pthread_mutex_init(&isPrintingOk,NULL);
    for(int i=0;i<3;++i) 
    {
        pthread_mutex_init(&step_mtx[i],NULL);
    }

    pthread_t threads[N+M];
    int visitor_ids[N+M];
    for(int i=0;i<N+M;i++)
    {
        visitor_ids[i]=(i<N)?1001+i:2001+(i-N);
        pthread_create(&threads[i],NULL,visitor,&visitor_ids[i]);
    }

    for(int i=0;i<N+M;i++)
    {
        pthread_join(threads[i],NULL);
    }

    sem_destroy(&gallery1_sem);
    sem_destroy(&corridor_sem);
    pthread_mutex_destroy(&isPrintingOk);
    for(int i=0;i<3;++i)
    {
        pthread_mutex_destroy(&step_mtx[i]);
    }
    return 0;
}