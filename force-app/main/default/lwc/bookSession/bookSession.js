import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import SPEAKER_SELECTED from '@salesforce/messageChannel/SpeakerSelected__c';
import isAvailable from '@salesforce/apex/SpeakerController.isAvailable';
import createAssignmentByDate from '@salesforce/apex/SpeakerController.createAssignmentByDate';
import getSpeaker from '@salesforce/apex/SpeakerController.getSpeaker';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BookSession extends LightningElement {
    speaker;
    speakerId;
    selectedDate;
    disableBtn = true;

    @wire(MessageContext) msgCtx;

    connectedCallback() {
        subscribe(this.msgCtx, SPEAKER_SELECTED, m => {
            this.speakerId = m.speakerId;
            getSpeaker({ speakerId: this.speakerId }).then(res => this.speaker = res);
        });
    }

   handleDate(e){
    this.selectedDate = e.target.value;

    // Reset button every time
    this.disableBtn = true;

    if(new Date(this.selectedDate) <= new Date()){
        this.toast('Error','Date must be in future','error');
        return;
    }

    isAvailable({ speakerId:this.speakerId, sessionDate:this.selectedDate })
        .then(ok => {
            if(ok){
                this.disableBtn = false;   // ENABLE button
            }else{
                this.disableBtn = true;
                this.toast('Error','Slot is already booked, try another date','error');
            }
        })
        .catch(err=>{
            this.toast('Error', err.body.message, 'error');
        });
}

    createAssignment(){
    createAssignmentByDate({
        speakerId: this.speakerId,
        sessionDate: this.selectedDate
    })
    .then(()=> this.toast('Success','Assignment Created','success'))
    .catch(e=> this.toast('Error', e.body.message, 'error'));
}


    toast(t,m,v){ this.dispatchEvent(new ShowToastEvent({title:t,message:m,variant:v})); }
}