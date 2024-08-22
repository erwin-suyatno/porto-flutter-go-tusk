package model

import (
	"time"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type User struct {
	Id        int       `gorm:"type:int; primaryKey:autoIncrement" json:"id"`
	Name      string    `gorm:"type:varchar(50)" json:"name"`
	Email     string    `gorm:"type:varchar(50)" json:"email,omitempty"`
	Password  string    `gorm:"type:varchar(255)" json:"password,omitempty"`
	Role      string    `gorm:"type:varchar(15)" json:"role,omitempty"`
	CreatedAt time.Time `json:"createdAt,omitempty"`
	UpdatedAt time.Time `json:"updatedAt,omitempty"`
	Tasks     []Task    `gorm:"constraint:OnDelete:CASCADE" json:"tasks,omitempty"`
}

func (u *User) AfterDelete(tx *gorm.DB) (err error) {
	tx.Clauses(clause.Returning{}).Where("user_id = ?", u.Id).Delete(&Task{})
	return
}
